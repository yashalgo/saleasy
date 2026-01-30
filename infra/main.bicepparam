using 'main.bicep'

param location = 'centralindia'
param environment = 'production'
param alertEmailAddresses = [
  // Add your email addresses here
  'salesmadeeasyforyou@gmail.com'
  // 'yash@example.com'
]
param openaiTpmRateLimit = 80
// If GPT-4o Mini is not available in Central India, override:
// param openaiRegion = 'eastus'
param openaiRegion = 'centralindia'
param deploySpeechEval = true
param deployStagingSlot = true
