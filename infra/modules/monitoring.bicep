// Application Insights + Log Analytics + Alert Rules

@description('Azure region')
param location string

@description('Email addresses for alert notifications')
param alertEmailAddresses array

@description('Resource tags')
param tags object

// ─── Log Analytics Workspace ──────────────────────────────────────────────────

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'salesvoice-logs'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

// ─── Application Insights ─────────────────────────────────────────────────────

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'salesvoice-insights'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ─── Action Group for Alerts ──────────────────────────────────────────────────

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'salesvoice-alerts'
  location: 'global'
  tags: tags
  properties: {
    groupShortName: 'sv-alerts'
    enabled: true
    emailReceivers: [
      for (email, i) in alertEmailAddresses: {
        name: 'alert-recipient-${i}'
        emailAddress: email
        useCommonAlertSchema: true
      }
    ]
  }
}

// ─── Alert 1: High Error Rate ─────────────────────────────────────────────────

resource highErrorRateAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'salesvoice-high-error-rate'
  location: 'global'
  tags: tags
  properties: {
    severity: 2
    enabled: true
    scopes: [appInsights.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'FailedRequests'
          metricName: 'requests/failed'
          metricNamespace: 'microsoft.insights/components'
          operator: 'GreaterThan'
          threshold: 50
          timeAggregation: 'Count'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
    description: 'Alert when failed requests exceed 50 in 15 minutes'
  }
}

// ─── Alert 2: Pipeline Latency Spike (Log-based) ─────────────────────────────

resource latencySpikeAlert 'Microsoft.Insights/scheduledQueryRules@2023-03-15-preview' = {
  name: 'salesvoice-pipeline-latency-spike'
  location: location
  tags: tags
  properties: {
    severity: 2
    enabled: true
    scopes: [appInsights.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT30M'
    criteria: {
      allOf: [
        {
          query: '''
            customMetrics
            | where name == "pipeline_stage_duration"
            | summarize avg(value) by bin(timestamp, 5m)
            | where avg_value > 300
          '''
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [actionGroup.id]
    }
    description: 'Alert when average pipeline stage duration exceeds 5 minutes'
  }
}

// ─── Alert 3: LLM Provider Failure (Circuit Breaker) ──────────────────────────

resource circuitBreakerAlert 'Microsoft.Insights/scheduledQueryRules@2023-03-15-preview' = {
  name: 'salesvoice-circuit-breaker-opened'
  location: location
  tags: tags
  properties: {
    severity: 1
    enabled: true
    scopes: [appInsights.id]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      allOf: [
        {
          query: '''
            traces
            | where message contains "circuit_breaker_opened"
            | count
          '''
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [actionGroup.id]
    }
    description: 'Critical: LLM provider circuit breaker has opened'
  }
}

// ─── Alert 4: Durable Functions Stuck ─────────────────────────────────────────

resource stuckOrchestrationAlert 'Microsoft.Insights/scheduledQueryRules@2023-03-15-preview' = {
  name: 'salesvoice-stuck-orchestrations'
  location: location
  tags: tags
  properties: {
    severity: 2
    enabled: true
    scopes: [appInsights.id]
    evaluationFrequency: 'PT10M'
    windowSize: 'PT30M'
    criteria: {
      allOf: [
        {
          query: '''
            traces
            | where message contains "orchestration"
            | where customDimensions.status == "Running"
            | where timestamp < ago(30m)
            | count
          '''
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 10
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [actionGroup.id]
    }
    description: 'Alert when more than 10 orchestrations are stuck for over 30 minutes'
  }
}

// ─── Outputs ──────────────────────────────────────────────────────────────────

output appInsightsName string = appInsights.name
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output logAnalyticsWorkspaceId string = logAnalytics.id
