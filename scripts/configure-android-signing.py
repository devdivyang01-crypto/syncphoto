#!/usr/bin/env python3
"""Wire Flutter's generated Gradle files to GitHub Actions signing secrets."""

from __future__ import annotations

import os
from pathlib import Path

android = Path("android")
properties = android / "key.properties"
gradle_kts = android / "app" / "build.gradle.kts"
gradle = android / "app" / "build.gradle"

properties.write_text(
    "\n".join(
        [
            "storePassword=" + os.environ["ANDROID_KEYSTORE_PASSWORD"],
            "keyPassword=" + os.environ["ANDROID_KEY_PASSWORD"],
            "keyAlias=" + os.environ["ANDROID_KEY_ALIAS"],
            "storeFile=app/release.keystore",
            "",
        ]
    ),
    encoding="utf-8",
)

signing_configs_kts = """
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }
"""

header_kts = """import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

"""

signing_configs_groovy = """
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile rootProject.file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
"""

header_groovy = """def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

"""

if gradle_kts.exists():
    text = gradle_kts.read_text(encoding="utf-8")
    if "keystoreProperties" not in text:
        text = header_kts + text
    if "create(\"release\")" not in text:
        text = text.replace("android {", "android {" + signing_configs_kts, 1)
    text = text.replace(
        'signingConfig = signingConfigs.getByName("debug")',
        'signingConfig = signingConfigs.getByName("release")',
    )
    gradle_kts.write_text(text, encoding="utf-8")
elif gradle.exists():
    text = gradle.read_text(encoding="utf-8")
    if "keystoreProperties" not in text:
        text = header_groovy + text
    if "signingConfigs {" not in text:
        text = text.replace("android {", "android {" + signing_configs_groovy, 1)
    text = text.replace(
        "signingConfig signingConfigs.debug",
        "signingConfig signingConfigs.release",
    )
    gradle.write_text(text, encoding="utf-8")
else:
    raise SystemExit("Could not find a Gradle build file to configure signing.")
