use iced::Element;

use crate::ui::window::GrassyWindow;

pub struct GrassyApp {
    window: GrassyWindow,
}

#[derive(Debug, Clone)]
pub enum Message {
    // We'll add application messages as we port the UI.
}

impl Default for GrassyApp {
    fn default() -> Self {
        Self {
            window: GrassyWindow::new(),
        }
    }
}

impl GrassyApp {
    pub fn title(&self) -> String {
        String::from("Grassy")
    }

    pub fn update(&mut self, _message: Message) {
        // We'll port application-level event handling here.
    }

    pub fn view(&self) -> Element<'_, Message> {
        self.window.view()
    }
}
