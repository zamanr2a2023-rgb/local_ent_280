const DEFAULT_HOST = '127.0.0.1';

export function parseEmulatorHostAndPort({
  emulatorHost,
  explicitPort,
  defaultPort,
  emulatorName
}) {
  const rawHost = emulatorHost?.trim();
  if (!rawHost) {
    return {
      host: DEFAULT_HOST,
      port: defaultPort
    };
  }

  const withoutProtocol = rawHost
    .replace(/^https?:\/\//, '')
    .replace(/\/$/, '');

  if (withoutProtocol.includes(':')) {
    const [parsedHost, parsedPort] = withoutProtocol.split(':');
    const port = Number.parseInt(parsedPort, 10);
    if (!Number.isNaN(port) && port > 0) {
      return {
        host: parsedHost,
        port
      };
    }
  }

  const fallbackPort = Number.parseInt(`${explicitPort ?? ''}`, 10);
  if (!Number.isNaN(fallbackPort) && fallbackPort > 0) {
    return {
      host: withoutProtocol,
      port: fallbackPort
    };
  }

  console.warn('[rules-test] Invalid emulator host/port configuration. Falling back to defaults.', {
    emulatorName,
    rawHost,
    defaultHost: DEFAULT_HOST,
    defaultPort
  });

  return {
    host: DEFAULT_HOST,
    port: defaultPort
  };
}
