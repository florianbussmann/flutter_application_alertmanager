package de.florianbussmann.alertmanager;

import android.os.RemoteException;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.UiDevice;

import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import tools.fastlane.screengrab.locale.LocaleTestRule;
import tools.fastlane.screengrab.Screengrab;

@RunWith(JUnit4.class)
public class JUnit4InstrumentedTest {
    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityScenarioRule<MainActivity> activityRule = new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void testTakeScreenshot() throws RemoteException {
        Screengrab.screenshot("Portrait");

        UiDevice device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());

        try {
            device.setOrientationLeft();
            Screengrab.screenshot("Landscape");
        } finally {
            device.unfreezeRotation();
        }
    }
}
