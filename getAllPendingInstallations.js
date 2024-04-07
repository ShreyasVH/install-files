const fs = require('fs');

(async () => {
	let versionHistory = JSON.parse(fs.readFileSync('versionHistory.json').toString());
	const staticVersionHistory = JSON.parse(fs.readFileSync('staticVersionHistory.json').toString());
	versionHistory = Object.assign({}, versionHistory, staticVersionHistory);

	const programData = JSON.parse(fs.readFileSync('programData.json').toString());
	const missingVersions = {};
	for (const [programName, details] of Object.entries(programData)) {
		if (details.isEntryPoint) {
			let eligibleVersions = versionHistory[programName].filter(item => new Date(item.releaseDateString).getTime() >= ((new Date('2023-07-01')).getTime()));
			if (eligibleVersions.length === 0) {
				eligibleVersions = [
					versionHistory[programName][0]
				]
			}
			// eligibleVersions = [eligibleVersions[0]]

			for (const versionDetails of eligibleVersions) {
				const version = versionDetails.version
				const pathToCheck = process.env.HOME + '/programs/' + programName + '/' + version + details.path;
				if (!fs.existsSync(pathToCheck)) {
					if (!missingVersions.hasOwnProperty(programName)) {
						missingVersions[programName] = [];
					}
					missingVersions[programName].push(version);
				}
			}
		}
	}

	fs.writeFileSync('allPendingVersions.json', JSON.stringify(missingVersions, null, ' '));
})();