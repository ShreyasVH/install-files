const fs = require('fs');

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const parseReleaseDate = releaseDateString => {
	const releaseDateParts = releaseDateString.split('/');
	const releaseDate = new Date(releaseDateParts[2], releaseDateParts[1] - 1, releaseDateParts[0]);
	return releaseDate;
};

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

const getDependencyVersions = (requiredProgram, requiredVersion) => {
	const programData = JSON.parse(fs.readFileSync('programData.json').toString());
	let versions = JSON.parse(fs.readFileSync('versionHistory.json').toString());
	const additionalVersions = JSON.parse(fs.readFileSync('staticVersionHistory.json').toString());
	versions = Object.assign({}, versions, additionalVersions);
	setSubVersionInfo(versions);

	let dependencyVersions = {};
	if (versions.hasOwnProperty(requiredProgram)) {
		const requiredObjects = versions[requiredProgram].filter(i => i.version === requiredVersion);
		if (requiredObjects.length > 0) {
			const requiredObject = requiredObjects[0];
			const releaseDate = new Date(requiredObject.releaseDateString);

			if (programData.hasOwnProperty(requiredProgram) && programData[requiredProgram].hasOwnProperty('dependencies') && programData[requiredProgram].dependencies.length > 0) {
				for (const dependencyProgram of programData[requiredProgram].dependencies) {
					let dependencyVersion;
					if (versions.hasOwnProperty(dependencyProgram)) {
						versions[dependencyProgram].sort((a, b) => {
							if ((new Date(a.releaseDateString)).getTime() > (new Date(b.releaseDateString)).getTime()) {
								return -1;
							} else if ((new Date(a.releaseDateString)).getTime() < (new Date(b.releaseDateString)).getTime()) {
								return 1;
							} else {
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
							}
						});

						// versions[dependencyProgram].sort((a, b) => {
						// 	if (a.majorVersion > b.majorVersion) {
						// 		return -1;
						// 	} else if (a.majorVersion < b.majorVersion) {
						// 		return 1;
						// 	} else {
						// 		if (a.minorVersion > b.minorVersion) {
						// 			return -1;
						// 		} else if (a.minorVersion < b.minorVersion) {
						// 			return 1;
						// 		} else {
						// 			if (a.patchVersion > b.patchVersion) {
						// 				return -1;
						// 			} else if (a.patchVersion < b.patchVersion) {
						// 				return 1;
						// 			} else {
						// 				return 0;
						// 			}
						// 		}
						// 	}
						// });

						console.log(JSON.stringify(versions[dependencyProgram], null, ' '));


						const eligibleVersions = versions[dependencyProgram].filter(i => (new Date(i.releaseDateString)).getTime() < releaseDate.getTime());
						if (eligibleVersions.length > 0) {
							dependencyVersion = eligibleVersions[0].version;
						} else {
							dependencyVersion = 'No version as per date';
						}
					} else {
						dependencyVersion = 'No versions';
					}
					dependencyVersions[dependencyProgram] = dependencyVersion;
				}
			}
		}
		
	}
	return dependencyVersions;
}

exports.getDependencyVersions = getDependencyVersions;

if (fileName === scriptName) {
	(async () => {
		const requiredProgram = process.argv[2];
		const requiredVersion = process.argv[3];
		const dependencyVersions = getDependencyVersions(requiredProgram, requiredVersion);
		console.log(JSON.stringify(dependencyVersions, null, ' '));
	})();
}