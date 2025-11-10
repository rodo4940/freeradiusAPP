const kAppName = 'FreeRadius App';
const kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8001/api',
);
const kConnectTimeoutMs = 8000;
const kRecvTimeoutMs = 10000;
