# Hey_Tutor.ppn — Picovoice Wake Word File

## Instructions to obtain this file:

1. Visit https://console.picovoice.ai and create a free account.
2. From the dashboard, copy your **AccessKey**.
3. Navigate to **Porcupine → Train Wake Word**.
4. Enter the phrase: `Hey Tutor`
5. Choose Language: **English**
6. Select Platform: **Android**
7. Click **Train** (takes 30–60 seconds).
8. Download the generated file (e.g. `Hey_Tutor_android.ppn`).
9. Rename it to `Hey_Tutor.ppn`.
10. Place it in this `assets/` folder (replacing this placeholder).
11. Paste your **AccessKey** into `lib/utils/constants.dart`.

> ⚠️ The free tier allows **3 monthly active users**.  
> For commercial deployment, upgrade to Picovoice Pro.

> ⚠️ Wake word detection does NOT work on Android emulators.  
> Always test on a **physical Android device**.
