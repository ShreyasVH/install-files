const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');
const path = require('path');

(async () => {
	const newVersion = process.argv[2];
	const program = 'sqlite3';

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const filePath = path.resolve(__dirname, '../../staticVersionMap.json');
		const details = JSON.parse(fs.readFileSync(filePath).toString());
		const date = new Date();
		details[program][newVersion] = {
			year: date.getFullYear()
		}
		fs.writeFileSync(filePath, JSON.stringify(details, null, ' '));

		await copyInstallFile(program, newVersion);
	}
})();