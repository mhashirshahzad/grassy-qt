use std::{
    env, fs,
    path::{Path, PathBuf},
    process::Command,
};

/// Get the directory where Grassy stores its servers.
///
/// Uses the same basic structure as the Python version:
/// - Linux:   ~/.config/grassy/settings.txt
///            ~/.local/share/grassy/servers
/// - macOS:   ~/Library/Application Support/grassy/...
/// - Windows: %APPDATA%/grassy/...
pub fn get_servers_dir() -> PathBuf {
    let config_dir = config_dir();
    let settings_file = config_dir.join("settings.txt");

    let data_dir = data_dir();
    let default_dir = data_dir.join("servers");

    // Try the saved directory first.
    if let Ok(saved) = fs::read_to_string(&settings_file) {
        let saved = saved.trim();

        if !saved.is_empty() {
            return PathBuf::from(saved);
        }
    }

    // Create the default servers directory.
    let _ = fs::create_dir_all(&default_dir);

    // Save the default path.
    if fs::create_dir_all(&config_dir).is_ok() {
        let _ = fs::write(&settings_file, default_dir.to_string_lossy().as_bytes());
    }

    default_dir
}

/// Save the servers directory to settings.txt.
pub fn save_servers_dir(path: &Path) -> bool {
    let config_dir = config_dir();
    let settings_file = config_dir.join("settings.txt");

    if fs::create_dir_all(&config_dir).is_err() {
        return false;
    }

    fs::write(settings_file, path.to_string_lossy().as_bytes()).is_ok()
}

/// Get the platform's config directory for Grassy.
fn config_dir() -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        env::var_os("APPDATA")
            .map(PathBuf::from)
            .unwrap_or_else(|| home_dir().join("AppData").join("Roaming"))
            .join("grassy")
    }

    #[cfg(target_os = "macos")]
    {
        home_dir()
            .join("Library")
            .join("Application Support")
            .join("grassy")
    }

    #[cfg(target_os = "linux")]
    {
        env::var_os("XDG_CONFIG_HOME")
            .map(PathBuf::from)
            .unwrap_or_else(|| home_dir().join(".config"))
            .join("grassy")
    }
}

/// Get the platform's data directory for Grassy.
fn data_dir() -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        env::var_os("APPDATA")
            .map(PathBuf::from)
            .unwrap_or_else(|| home_dir().join("AppData").join("Roaming"))
            .join("grassy")
    }

    #[cfg(target_os = "macos")]
    {
        home_dir()
            .join("Library")
            .join("Application Support")
            .join("grassy")
    }

    #[cfg(target_os = "linux")]
    {
        env::var_os("XDG_DATA_HOME")
            .map(PathBuf::from)
            .unwrap_or_else(|| home_dir().join(".local").join("share"))
            .join("grassy")
    }
}

fn home_dir() -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        env::var_os("USERPROFILE")
            .map(PathBuf::from)
            .unwrap_or_else(|| PathBuf::from("."))
    }

    #[cfg(not(target_os = "windows"))]
    {
        env::var_os("HOME")
            .map(PathBuf::from)
            .unwrap_or_else(|| PathBuf::from("."))
    }
}

/// Kill processes currently using `port`.
///
/// Returns the number of processes killed.
pub fn kill_process_on_port(port: u16) -> usize {
    #[cfg(target_os = "windows")]
    {
        kill_process_on_port_windows(port)
    }

    #[cfg(not(target_os = "windows"))]
    {
        kill_process_on_port_unix(port)
    }
}

#[cfg(target_os = "windows")]
fn kill_process_on_port_windows(port: u16) -> usize {
    let output = match Command::new("cmd")
        .args(["/C", &format!("netstat -ano | findstr :{port}")])
        .output()
    {
        Ok(output) => output,
        Err(error) => {
            eprintln!("Error finding process on port {port}: {error}");
            return 0;
        }
    };

    let stdout = String::from_utf8_lossy(&output.stdout);

    let mut pids = Vec::new();

    for line in stdout.lines() {
        let parts: Vec<&str> = line.split_whitespace().collect();

        if let Some(pid) = parts.last() {
            if !pids.contains(pid) {
                pids.push(*pid);
            }
        }
    }

    let count = pids.len();

    for pid in pids {
        let _ = Command::new("taskkill").args(["/PID", pid, "/F"]).status();
    }

    count
}

#[cfg(not(target_os = "windows"))]
fn kill_process_on_port_unix(port: u16) -> usize {
    let output = match Command::new("lsof")
        .args(["-t", &format!("-i:{port}")])
        .output()
    {
        Ok(output) => output,
        Err(error) => {
            eprintln!("Error finding process on port {port}: {error}");
            return 0;
        }
    };

    let stdout = String::from_utf8_lossy(&output.stdout);

    let mut count = 0;

    for pid in stdout.split_whitespace() {
        match pid.parse::<u32>() {
            Ok(pid) => {
                let status = Command::new("kill").args(["-9", &pid.to_string()]).status();

                if status.is_ok_and(|status| status.success()) {
                    count += 1;
                }
            }
            Err(_) => {}
        }
    }

    count
}

/// Check whether Java is installed.
pub fn is_java_installed() -> bool {
    Command::new("java")
        .arg("-version")
        .output()
        .is_ok_and(|output| output.status.success())
}
