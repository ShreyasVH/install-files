const fs = require('fs');

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const setSubVersionInfo = require('./utils').setSubVersionInfo;

const getLatestVersions = () => {
	let versions = JSON.parse(fs.readFileSync('versionHistory.json').toString());
	const additionalVersions = JSON.parse(fs.readFileSync('staticVersionHistory.json').toString());
	versions = Object.assign({}, versions, additionalVersions);
	setSubVersionInfo(versions);

	const latestVersions = {};

	for (const [program, programVersions] of Object.entries(versions)) {
		programVersions.sort((a, b) => {
			if (a.majorVersion > b.majorVersion) {
				return -1;
			} else if (a.majorVersion < b.majorVersion) {
				return 1;
			} else {
				if (a.minorVersion > b.minorVersion) {
					return -1;
				} else if (a.minorVersion < b.minorVersion) {
					return 1;
				} else {
					if (a.patchVersion > b.patchVersion) {
						return -1;
					} else if (a.patchVersion < b.patchVersion) {
						return 1;
					} else {
						return 0;
					}
				}
			}
		});


		latestVersions[program] = programVersions[0].version;
	}

	const latestVersionsFilePath = 'latestVersions.json';
	fs.writeFileSync(latestVersionsFilePath, JSON.stringify(latestVersions, null, ' '));
}


if (fileName === scriptName) {
	(async () => {
		getLatestVersions();
	})();
}