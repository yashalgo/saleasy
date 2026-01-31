// Budget & Cost Alerts

@description('Email addresses for budget notifications')
param alertEmailAddresses array

@description('Resource tags')
param tags object

// ─── Total Credits Budget ($1000) ─────────────────────────────────────────────

resource creditsBudget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: 'salesvoice-credits-monitor'
  properties: {
    category: 'Cost'
    amount: 1000
    timeGrain: 'Annually'
    timePeriod: {
      startDate: '2026-02-01'
      endDate: '2027-01-31'
    }
    notifications: {
      alert10pct: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 10
        contactEmails: alertEmailAddresses
        thresholdType: 'Actual'
      }
      alert50pct: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 50
        contactEmails: alertEmailAddresses
        thresholdType: 'Actual'
      }
      alert80pct: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: alertEmailAddresses
        thresholdType: 'Actual'
      }
    }
  }
}

// ─── Monthly Spend Budget ($120) ──────────────────────────────────────────────

resource monthlyBudget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: 'salesvoice-monthly-guard'
  properties: {
    category: 'Cost'
    amount: 120
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: '2026-02-01'
      endDate: '2027-01-31'
    }
    notifications: {
      alert90pct: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 90
        contactEmails: alertEmailAddresses
        thresholdType: 'Actual'
      }
    }
  }
}
