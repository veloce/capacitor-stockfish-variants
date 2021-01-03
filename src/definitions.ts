declare module '@capacitor/core' {
  interface PluginRegistry {
    StockfishVariants: StockfishPlugin
  }
}

export interface StockfishPlugin {
  getMaxMemory(): Promise<{ value: number }>
  start(): Promise<void>
  cmd(options: { cmd: string }): Promise<void>
  exit(): Promise<void>
}
