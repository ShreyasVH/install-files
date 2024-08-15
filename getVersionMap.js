const fs = require('fs');

const getDependencyVersions = require('./getDependencyVersionsV2.js').getDependencyVersions;

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
					console.log(version);
					versionMap[programName][version] = await getDependencyVersions(programName, version);
				// }
			}
		}
	}

	fs.writeFileSync('versionMap.json', JSON.stringify(versionMap, null, ' '));
})();