const kAppName = 'FreeRadius App';
const kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);
const kConnectTimeoutMs = 8000;
const kRecvTimeoutMs = 10000;
