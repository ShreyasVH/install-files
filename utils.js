
const setSubVersionInfo = (versionsData) => {
	for (const [programName, versions] of Object.entries(versionsData)) {
		versions.forEach(versionDetails => {
			const version = versionDetails.version;
			const parts = version.split('.');
			if (parts.length > 3) {
				parts[2] = parseInt(parts[2] + parts[3]);
			}
			const majorVersion = parseInt(parts[0]);
			const minorVersion = parseInt(parts[1]);
			const patchVersion = parseInt(parts[2]);

			versionDetails.majorVersion = majorVersion;
			versionDetails.minorVersion = minorVersion;
			versionDetails.patchVersion = patchVersion;
		});
	}
}




exports.setSubVersionInfo = setSubVersionInfo;