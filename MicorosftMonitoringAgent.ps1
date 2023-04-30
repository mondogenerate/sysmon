# https://learn.microsoft.com/EN-us/azure/azure-monitor/agents/azure-monitor-agent-windows-client
Invoke-WebRequest https://go.microsoft.com/fwlink/?linkid=2192409 -o AzureMonitorAgentClientSetup.msi
msiexec /i AzureMonitorAgentClientSetup.msi /qn
