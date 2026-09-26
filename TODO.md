# TODO

## Server settings popup

- [ ] Do not use `CustomTextField` in `ServerSettingsPopup`; use the graphical controls directly for server properties.
- [ ] Fix `SettingsPopup.qml:56`: `closeButton` is not defined in the popup scope. Use the close-button API exposed by `CustomPopup`.
- [ ] Fix `ServerCard.qml:151`: `ServerSettingsPopup` does not expose `propertiesText`. Update the card to use the popup's current graphical settings API.
- [ ] Restore `ServerSettingsPopup` opening from `ServerCard` after the property/API mismatch is fixed.
- [ ] Verify the popup under QML runtime and confirm server-property loading and saving work.
