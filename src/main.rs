mod app;
mod ui;

fn main() -> iced::Result {
    iced::application(
        app::GrassyApp::title,
        app::GrassyApp::update,
        app::GrassyApp::view,
    )
    .run()
}
