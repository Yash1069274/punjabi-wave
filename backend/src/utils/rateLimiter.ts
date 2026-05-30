export class SerialRateLimiter {
  private nextAvailableAt = 0;
  private queue = Promise.resolve();

  constructor(private readonly intervalMs: number) {}

  schedule<T>(fn: () => Promise<T>): Promise<T> {
    const run = this.queue.then(async () => {
      const waitMs = Math.max(0, this.nextAvailableAt - Date.now());
      if (waitMs > 0) await new Promise((resolve) => setTimeout(resolve, waitMs));
      this.nextAvailableAt = Date.now() + this.intervalMs;
      return fn();
    });
    this.queue = run.then(() => undefined, () => undefined);
    return run;
  }
}
