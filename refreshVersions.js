const getAllVersionsGithub = require('./src/getVersionsScripts/github.js').getAllVersions;
const getAllVersionsGnu = require('./src/getVersionsScripts/gnu.js').getAllVersions;
const getAllVersionsPecl = require('./src/getVersionsScripts/pecl.js').getAllVersions;
const capitalize = require('./src/utils').capitalize;
const fs = require('fs');


(async () => {
	const filePath = 'programData.json';
	const programData = JSON.parse(fs.readFileSync(filePath).toString());
	for (const [programName, details] of Object.entries(programData)) {
		if (details.tagsUrl && (!details.versionsLastUpdatedOn || (details.versionsLastUpdatedOn < ((new Date).getTime() - (24 * 3600 * 1000))))) {
			console.log(programName);
			if (details.scriptName) {
				const scriptName = `getAllVersions${capitalize(details.scriptName)}`;
				console.log(scriptName);
				// await getAllVersions(programName, details.tagsUrl);
			}
			

			// programData[programName].versionsLastUpdatedOn = (new Date()).getTime();
			// fs.writeFileSync(filePath, JSON.stringify(programData, null, ' '));
		}
	}
})();