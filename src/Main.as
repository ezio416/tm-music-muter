// c 2024-06-24
// m 2024-06-24

float        gottenVolume  = 0.0f;
const float  maxVolume     = 0.0f;
const float  minVolume     = -40.0f;
bool         muted         = false;
const float  scale         = UI::GetScale();
bool         settingVolume = false;
const string title         = "\\$FFF" + Icons::Music + "\\$G Music Muter";
bool         waitingForKey = false;

void Main() {
    gottenVolume = MusicVolume();
    S_Volume = gottenVolume;

    bool customMusic = false;
    bool inMap       = InMap();
    bool wasInMap    = inMap;

    while (true) {
        yield();

        if (!S_Enabled)
            continue;

        inMap = InMap();

        if (inMap && !wasInMap) {
            wasInMap = true;

            if (false
                || (customMusic && S_MuteEnterCustom)
                || (!customMusic && S_MuteEnterNoCustom)
            )
                Mute();

            if (false
                || (customMusic && S_UnmuteEnterCustom)
                || (!customMusic && S_UnmuteEnterNoCustom)
            )
                Unmute();
        }

        if (!inMap && wasInMap) {
            wasInMap = false;

            if (false
                || (customMusic && S_MuteLeaveCustom)
                || (!customMusic && S_MuteLeaveNoCustom)
            )
                Mute();

            if (false
                || (customMusic && S_UnmuteLeaveCustom)
                || (!customMusic && S_UnmuteLeaveNoCustom)
            )
                Unmute();
        }

        customMusic = CurrentMapHasMusic();
    }
}

void OnDestroyed() { MusicVolume(gottenVolume); }
void OnDisabled()  { MusicVolume(gottenVolume); }

void OnKeyPress(bool down, VirtualKey key) {
    if (!down)
        return;

    if (waitingForKey) {
        if (key != VirtualKey::Escape)
            S_Hotkey = key;

        waitingForKey = false;
        return;
    }

    if (key == S_Hotkey)
        ToggleMute();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

bool CurrentMapHasMusic() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.RootMap is null)
        return false;

    return App.RootMap.CustomMusicPackDesc !is null;
}

bool InMap() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return App.RootMap !is null
        && App.CurrentPlayground !is null
        && App.Editor is null;
}

float MusicVolume(float volume = 1.0f) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.AudioPort is null)
        return minVolume;

    if (volume >= minVolume && volume <= maxVolume) {
        trace("setting music volume to " + volume);
        App.AudioPort.MusicVolume = volume;
    }

    return App.AudioPort.MusicVolume;
}

void Mute() {
    MusicVolume(minVolume);
    trace("muted");
    muted = true;
}

void ToggleMute(bool opposite = false) {
    if (opposite)
        muted = !muted;

    if (muted)
        Unmute();
    else
        Mute();
}

void Unmute() {
    MusicVolume(S_Volume);
    trace("unmuted");
    muted = false;
}
