const fs = require('fs');
const setSubVersionInfo = require('./utils').setSubVersionInfo;

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
						// versions[dependencyProgram].sort((a, b) => {
						// 	if ((new Date(a.releaseDateString)).getTime() > (new Date(b.releaseDateString)).getTime()) {
						// 		return -1;
						// 	} else if ((new Date(a.releaseDateString)).getTime() < (new Date(b.releaseDateString)).getTime()) {
						// 		return 1;
						// 	} else {
						// 		if (a.majorVersion > b.majorVersion) {
						// 			return -1;
						// 		} else if (a.majorVersion < b.majorVersion) {
						// 			return 1;
						// 		} else {
						// 			if (a.minorVersion > b.minorVersion) {
						// 				return -1;
						// 			} else if (a.minorVersion < b.minorVersion) {
						// 				return 1;
						// 			} else {
						// 				if (a.patchVersion > b.patchVersion) {
						// 					return -1;
						// 				} else if (a.patchVersion < b.patchVersion) {
						// 					return 1;
						// 				} else {
						// 					return 0;
						// 				}
						// 			}
						// 		}
						// 	}
						// });

						versions[dependencyProgram].sort((a, b) => {
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

						// console.log(JSON.stringify(versions[dependencyProgram], null, ' '));


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

(async () => {
	const programData = JSON.parse(fs.readFileSync('programData.json').toString());
	let versionHistory = JSON.parse(fs.readFileSync('versionHistory.json').toString());
	const staticVersionHistory = JSON.parse(fs.readFileSync('staticVersionHistory.json').toString());
	versionHistory = Object.assign({}, versionHistory, staticVersionHistory);

	const versionMap = {};
	for (const [programName, details] of Object.entries(programData)) {
		console.log(programName);
		if (details.hasOwnProperty('dependencies') && versionHistory.hasOwnProperty(programName)) {
			// console.log(versionHistory[programName].length);
			for (const versionDetails of versionHistory[programName]) {
				// if ((new Date(versionDetails.releaseDateString)).getTime() > ((new Date()).getTime() - 365 * 24 * 3600 * 1000)) {
				// console.log(programName);
					if (!versionMap.hasOwnProperty(programName)) {
						versionMap[programName] = {};
					}
					
					const version = versionDetails.version;
					// console.log(version);
					versionMap[programName][version] = await getDependencyVersions(programName, version);
				// }
			}
		}
	}

	fs.writeFileSync('versionMap.json', JSON.stringify(versionMap, null, ' '));
})();