const getAllVersions = require('./getVersions.js').getAllVersions;
const fs = require('fs');


(async () => {
	const filePath = 'programData.json';
	const programData = JSON.parse(fs.readFileSync(filePath).toString());
	for (const [programName, details] of Object.entries(programData)) {
		if (details.tagsUrl && (!details.versionsLastUpdatedOn || (details.versionsLastUpdatedOn < ((new Date).getTime() - (24 * 3600 * 1000))))) {
			console.log(programName);
			await getAllVersions(programName, details.tagsUrl);

			programData[programName].versionsLastUpdatedOn = (new Date()).getTime();
			fs.writeFileSync(filePath, JSON.stringify(programData, null, ' '));
		}
	}
})();