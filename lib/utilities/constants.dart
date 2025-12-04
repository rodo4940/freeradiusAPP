const kAppName = 'InfRadius';
const kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.43.63:8001/api',
);
const kConnectTimeoutMs = 8000;
const kRecvTimeoutMs = 10000;
