/// GPU information struct exposed to Dart
#[derive(Clone)]
pub struct GpuInfo {
    pub device_name: String,
    pub memory_mb: u64,
}

/// Query all available GPUs
#[flutter_rust_bridge::frb(sync)]
pub fn get_gpus_info() -> Vec<GpuInfo> {
    #[cfg(target_os = "windows")]
    {
        get_gpus_info_windows()
    }

    #[cfg(not(target_os = "windows"))]
    {
        // Stubbed for macOS and Linux
        Vec::new()
    }
}

/// Get GPU with most memory (or first available if memory not reported)
#[flutter_rust_bridge::frb(sync)]
pub fn get_best_gpu() -> Option<GpuInfo> {
    let gpus = get_gpus_info();

    // If memory is reported, pick the one with most memory
    // Otherwise just return the first one (typically the discrete GPU)
    gpus.into_iter().max_by_key(|gpu| gpu.memory_mb)
}

#[cfg(target_os = "windows")]
fn get_gpus_info_windows() -> Vec<GpuInfo> {
    use windows::Win32::Graphics::Dxgi::{CreateDXGIFactory1, IDXGIAdapter1, IDXGIFactory1};

    let mut gpus = Vec::new();

    unsafe {
        let factory: IDXGIFactory1 = match CreateDXGIFactory1() {
            Ok(f) => f,
            Err(_) => return gpus,
        };

        let mut adapter_index: u32 = 0;
        loop {
            let adapter: IDXGIAdapter1 = match factory.EnumAdapters1(adapter_index) {
                Ok(a) => a,
                Err(_) => break,
            };

            if let Ok(desc) = adapter.GetDesc1() {
                // Skip software adapters (like Microsoft Basic Render Driver)
                const DXGI_ADAPTER_FLAG_SOFTWARE: u32 = 2;
                if (desc.Flags & DXGI_ADAPTER_FLAG_SOFTWARE) == 0 {
                    // Convert wide string to Rust String
                    let name_len = desc
                        .Description
                        .iter()
                        .position(|&c| c == 0)
                        .unwrap_or(desc.Description.len());
                    let device_name =
                        String::from_utf16_lossy(&desc.Description[..name_len]);

                    // DedicatedVideoMemory is in bytes, convert to MB
                    let memory_mb = desc.DedicatedVideoMemory as u64 / (1024 * 1024);

                    gpus.push(GpuInfo {
                        device_name,
                        memory_mb,
                    });
                }
            }

            adapter_index += 1;
        }
    }

    gpus
}
