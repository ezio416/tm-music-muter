// c 2024-06-24
// m 2024-06-24

[Setting hidden] bool       S_Enabled             = true;
[Setting hidden] float      S_Volume              = minVolume;
[Setting hidden] VirtualKey S_Hotkey              = VirtualKey::M;
[Setting hidden] bool       S_MuteEnterCustom     = false;
[Setting hidden] bool       S_UnmuteEnterCustom   = false;
[Setting hidden] bool       S_MuteLeaveCustom     = false;
[Setting hidden] bool       S_UnmuteLeaveCustom   = false;
[Setting hidden] bool       S_MuteEnterNoCustom   = false;
[Setting hidden] bool       S_UnmuteEnterNoCustom = false;
[Setting hidden] bool       S_MuteLeaveNoCustom   = false;
[Setting hidden] bool       S_UnmuteLeaveNoCustom = false;

[SettingsTab name="General" icon="Cogs"]
void Settings_General() {
    if (UI::Button("Reset to default")) {
        Meta::PluginSetting@[]@ settings = Meta::ExecutingPlugin().GetSettings();

        for (uint i = 0; i < settings.Length; i++)
            settings[i].Reset();

        S_Volume = gottenVolume;
        Unmute();
    }

    S_Enabled = UI::Checkbox("Enabled", S_Enabled);

    const bool mutedPre = muted;
    muted = UI::Checkbox("Mute", muted);
    if (muted != mutedPre)
        ToggleMute(true);

    const float volumePre = S_Volume;
    S_Volume = UI::SliderFloat("Normal music volume", S_Volume, minVolume, maxVolume, "%.1f", UI::SliderFlags::NoInput);
    HoverTooltipSetting("Grabbed from the game's settings at plugin start");
    if (S_Volume < minVolume)
        S_Volume = minVolume;
    else if (S_Volume > maxVolume)
        S_Volume = maxVolume;
    if (S_Volume != volumePre)
        settingVolume = true;
    if (settingVolume && !muted && !UI::IsMouseDown()) {
        settingVolume = false;
        Unmute();
    }

    UI::Separator();

    if (UI::BeginCombo("Toggle hotkey", tostring(S_Hotkey))) {
        const uint end = uint(VirtualKey::OemClear);

        for (uint i = 0; i <= end; i++) {
            const VirtualKey key = VirtualKey(i);
            const string keyStr = tostring(key);

            if (keyStr == tostring(i))
                continue;

            if (UI::Selectable(keyStr, key == S_Hotkey)) {
                S_Hotkey = key;
                break;
            }
        }

        UI::EndCombo();
    }

    UI::BeginDisabled(waitingForKey);
    if (UI::Button(waitingForKey ? "Waiting for key press... (escape to cancel)" : "Auto-detect key"))
        waitingForKey = true;
    UI::EndDisabled();

    UI::Separator();

    if (UI::BeginTable("table-mute-unmute", 3)) {
        UI::TableSetupColumn("");
        UI::TableSetupColumn("Mute",   UI::TableColumnFlags::WidthFixed, scale * 100.0f);
        UI::TableSetupColumn("Unmute", UI::TableColumnFlags::WidthFixed, scale * 100.0f);
        UI::TableHeadersRow();

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text("Entering map with custom music");
        UI::TableNextColumn();
        S_MuteEnterCustom = UI::Checkbox("##mute-enter-custom", S_MuteEnterCustom);
        if (S_MuteEnterCustom && S_UnmuteEnterCustom)
            S_UnmuteEnterCustom = false;
        UI::TableNextColumn();
        S_UnmuteEnterCustom = UI::Checkbox("##unmute-enter-custom", S_UnmuteEnterCustom);
        if (S_MuteEnterCustom && S_UnmuteEnterCustom)
            S_MuteEnterCustom = false;

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text("Leaving map with custom music");
        UI::TableNextColumn();
        S_MuteLeaveCustom = UI::Checkbox("##mute-leave-custom", S_MuteLeaveCustom);
        if (S_MuteLeaveCustom && S_UnmuteLeaveCustom)
            S_UnmuteLeaveCustom = false;
        UI::TableNextColumn();
        S_UnmuteLeaveCustom = UI::Checkbox("##unmute-leave-custom", S_UnmuteLeaveCustom);
        if (S_MuteLeaveCustom && S_UnmuteLeaveCustom)
            S_MuteLeaveCustom = false;

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text("Entering map without custom music");
        UI::TableNextColumn();
        S_MuteEnterNoCustom = UI::Checkbox("##mute-enter-no-custom", S_MuteEnterNoCustom);
        if (S_MuteEnterNoCustom && S_UnmuteEnterNoCustom)
            S_UnmuteEnterNoCustom = false;
        UI::TableNextColumn();
        S_UnmuteEnterNoCustom = UI::Checkbox("##unmute-enter-no-custom", S_UnmuteEnterNoCustom);
        if (S_MuteEnterNoCustom && S_UnmuteEnterNoCustom)
            S_MuteEnterNoCustom = false;

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text("Leaving map without custom music");
        UI::TableNextColumn();
        S_MuteLeaveNoCustom = UI::Checkbox("##mute-leave-no-custom", S_MuteLeaveNoCustom);
        if (S_MuteLeaveNoCustom && S_UnmuteLeaveNoCustom)
            S_UnmuteLeaveNoCustom = false;
        UI::TableNextColumn();
        S_UnmuteLeaveNoCustom = UI::Checkbox("##unmute-leave-no-custom", S_UnmuteLeaveNoCustom);
        if (S_MuteLeaveNoCustom && S_UnmuteLeaveNoCustom)
            S_MuteLeaveNoCustom = false;

        UI::EndTable();
    }
}

void HoverTooltipSetting(const string &in msg) {
    UI::SameLine();
    UI::Text("\\$666" + Icons::QuestionCircle);
    if (!UI::IsItemHovered())
        return;

    UI::SetNextWindowSize(int(Math::Min(Draw::MeasureString(msg).x, 400.0f)), 0.0f);
    UI::BeginTooltip();
    UI::TextWrapped(msg);
    UI::EndTooltip();
}
