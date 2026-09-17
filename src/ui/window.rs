use std::{fs, path::PathBuf};

use iced::widget::{button, column, container, row, scrollable, text, text_input};
use iced::{Element, Length};

use crate::utils::{get_servers_dir, is_java_installed};

use super::{
    card::ServerCard,
    card_editor,
    downloader::{
        fabric::FabricDownloaderWindow, forge::ForgeDownloaderWindow,
        minecraft::MinecraftDownloaderWindow,
    },
    server_runner::ServerRunnerWindow,
    settings::SettingsWindow,
};

pub struct GrassyWindow {
    // -------------------------
    // SERVER LIST
    // -------------------------
    pub server_cards: Vec<(String, ServerCard)>,

    // -------------------------
    // SEARCH
    // -------------------------
    pub search_query: String,

    // -------------------------
    // JAVA STATUS
    // -------------------------
    pub java_installed: bool,

    // -------------------------
    // CHILD WINDOWS
    // -------------------------
    //
    // Iced does not have GTK-style child windows directly attached
    // to a parent window. We keep their state here and render/manage
    // them through Messages.
    //
    pub settings: Option<SettingsWindow>,
    pub minecraft_downloader: Option<MinecraftDownloaderWindow>,
    pub forge_downloader: Option<ForgeDownloaderWindow>,
    pub fabric_downloader: Option<FabricDownloaderWindow>,
    pub server_runner: Option<ServerRunnerWindow>,
}

impl GrassyWindow {
    pub fn new() -> Self {
        let mut window = Self {
            server_cards: Vec::new(),
            search_query: String::new(),
            java_installed: false,

            settings: None,
            minecraft_downloader: None,
            forge_downloader: None,
            fabric_downloader: None,
            server_runner: None,
        };

        window.refresh_server_list();
        window.update_java_status();

        window
    }

    // ============================================================
    // JAVA STATUS
    // ============================================================

    pub fn update_java_status(&mut self) {
        self.java_installed = is_java_installed();
    }

    // ============================================================
    // SERVER LOADING
    // ============================================================

    pub fn refresh_server_list(&mut self) {
        self.server_cards.clear();

        let servers_dir = get_servers_dir();

        if !servers_dir.exists() {
            if let Err(error) = fs::create_dir_all(&servers_dir) {
                eprintln!(
                    "Failed to create servers directory {}: {error}",
                    servers_dir.display()
                );
            }

            return;
        }

        let mut server_folders = Vec::new();

        let entries = match fs::read_dir(&servers_dir) {
            Ok(entries) => entries,
            Err(error) => {
                eprintln!(
                    "Failed to read servers directory {}: {error}",
                    servers_dir.display()
                );
                return;
            }
        };

        for entry in entries.flatten() {
            let path = entry.path();

            if path.is_dir() && path.join("server.jar").exists() {
                server_folders.push(path);
            }
        }

        // Python:
        //
        // for folder in sorted(server_folders):
        //
        // PathBuf implements Ord, so this gives deterministic ordering.
        server_folders.sort();

        for folder in server_folders {
            let name = folder
                .file_name()
                .and_then(|name| name.to_str())
                .unwrap_or_default()
                .to_string();

            let card = ServerCard::new(folder.clone());

            self.server_cards.push((name.to_lowercase(), card));
        }
    }

    // ============================================================
    // SEARCH
    // ============================================================

    pub fn search_changed(&mut self, query: String) {
        self.search_query = query.trim().to_lowercase();
    }

    // ============================================================
    // ACTIONS
    // ============================================================

    pub fn open_official_downloader(&mut self) {
        self.minecraft_downloader = Some(MinecraftDownloaderWindow::new());
    }

    pub fn open_forge_downloader(&mut self) {
        self.forge_downloader = Some(ForgeDownloaderWindow::new());
    }

    pub fn open_fabric_downloader(&mut self) {
        self.fabric_downloader = Some(FabricDownloaderWindow::new());
    }

    pub fn open_settings(&mut self) {
        self.settings = Some(SettingsWindow::new());
    }

    // ============================================================
    // VIEW
    // ============================================================

    pub fn view(&self) -> Element<'_, Message> {
        let header = self.header();

        let server_list = self.server_list();

        let java_status = self.java_status();

        column![header, server_list, java_status,]
            .height(Length::Fill)
            .into()
    }

    // ============================================================
    // HEADER
    // ============================================================

    fn header(&self) -> Element<'_, Message> {
        let settings_button = button(text("⚙")).on_press(Message::SettingsClicked);

        let search = text_input("Search servers...", &self.search_query)
            .on_input(Message::SearchChanged)
            .width(180);

        let download_button = button(text("+")).on_press(Message::DownloadMenu);

        let scan_button = button(text("↻")).on_press(Message::ScanClicked);

        row![
            settings_button,
            text("Grassy - Minecraft Server Manager"),
            search,
            download_button,
            scan_button,
        ]
        .spacing(8)
        .padding(8)
        .align_y(iced::Alignment::Center)
        .into()
    }

    // ============================================================
    // SERVER LIST
    // ============================================================

    fn server_list(&self) -> Element<'_, Message> {
        let query = self.search_query.as_str();

        let mut content = column![].spacing(6).padding(12);

        let mut visible_cards = 0;

        for (name, card) in &self.server_cards {
            if query.is_empty() || name.contains(query) {
                content = content.push(card.view().map(Message::ServerCard));

                visible_cards += 1;
            }
        }

        if visible_cards == 0 {
            return scrollable(self.empty_state()).height(Length::Fill).into();
        }

        scrollable(content).height(Length::Fill).into()
    }

    // ============================================================
    // EMPTY STATE
    // ============================================================

    fn empty_state(&self) -> Element<'_, Message> {
        let servers_dir = get_servers_dir();

        let message = format!(
            "Create folders in:\n{}\nwith server.jar inside",
            servers_dir.display()
        );

        let content = column![
            text("📁").size(64),
            text("No servers found").size(24),
            text(message),
            button("Download Server").on_press(Message::DownloadMenu),
        ]
        .spacing(12)
        .align_x(iced::Alignment::Center);

        container(content)
            .width(Length::Fill)
            .height(Length::Fill)
            .center_x(Length::Fill)
            .center_y(Length::Fill)
            .into()
    }

    // ============================================================
    // JAVA STATUS
    // ============================================================

    fn java_status(&self) -> Element<'_, Message> {
        let (dot, label) = if self.java_installed {
            ("●", "Java detected")
        } else {
            ("●", "Java not found")
        };

        row![text(dot), text(label).size(16),]
            .spacing(6)
            .padding([6, 12])
            .align_y(iced::Alignment::Center)
            .into()
    }
}

// ====================================================================
// MESSAGES
// ====================================================================

#[derive(Debug, Clone)]
pub enum Message {
    // -------------------------
    // HEADER
    // -------------------------
    SearchChanged(String),

    SettingsClicked,

    ScanClicked,

    DownloadMenu,

    // -------------------------
    // DOWNLOADERS
    // -------------------------
    DownloadOfficial,

    DownloadForge,

    DownloadFabric,

    // -------------------------
    // CHILD WINDOWS
    // -------------------------
    Settings(SettingsWindowMessage),

    MinecraftDownloader(MinecraftDownloaderMessage),

    ForgeDownloader(ForgeDownloaderMessage),

    FabricDownloader(FabricDownloaderMessage),

    ServerRunner(ServerRunnerMessage),

    // -------------------------
    // SERVER CARDS
    // -------------------------
    ServerCard(ServerCardMessage),

    // -------------------------
    // REFRESH
    // -------------------------
    RefreshServers,

    UpdateJavaStatus,
}

// ====================================================================
// CHILD MESSAGE TYPES
// ====================================================================
//
// These are placeholders until we port the corresponding Python files.
// They keep the architecture clean instead of coupling this window
// directly to their internal implementation.
//

#[derive(Debug, Clone)]
pub enum SettingsWindowMessage {
    // TODO: port ui/settings.py
}

#[derive(Debug, Clone)]
pub enum MinecraftDownloaderMessage {
    // TODO: port ui/downloader/minecraft.py
}

#[derive(Debug, Clone)]
pub enum ForgeDownloaderMessage {
    // TODO: port ui/downloader/forge.py
}

#[derive(Debug, Clone)]
pub enum FabricDownloaderMessage {
    // TODO: port ui/downloader/fabric.py
}

#[derive(Debug, Clone)]
pub enum ServerRunnerMessage {
    // TODO: port ui/server_runner/*
}

#[derive(Debug, Clone)]
pub enum ServerCardMessage {
    // TODO: port ui/card.py
}
