const fs = require('fs');

(async () => {
	let versionHistory = JSON.parse(fs.readFileSync('versionHistory.json').toString());
	const staticVersionHistory = JSON.parse(fs.readFileSync('staticVersionHistory.json').toString());
	versionHistory = Object.assign({}, versionHistory, staticVersionHistory);
	const latestVersions = JSON.parse(fs.readFileSync('latestVersions.json').toString());

	const programData = JSON.parse(fs.readFileSync('programData.json').toString());
	const missingVersions = {};
	for (const [programName, details] of Object.entries(programData)) {
		if (details.isEntryPoint) {
			const latestVersion = latestVersions[programName]
			const pathToCheck = process.env.HOME + '/programs/' + programName + '/' + latestVersion + details.path;
			if (!fs.existsSync(pathToCheck)) {
				if (!missingVersions.hasOwnProperty(programName)) {
					missingVersions[programName] = [];
				}
				missingVersions[programName].push(latestVersion);
			}
		}
	}

	fs.writeFileSync('pendingVersions.json', JSON.stringify(missingVersions, null, ' '));
})();