const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'postgres';

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {
		const previousConfigFilePath1 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/pg_hba.conf`;
		const previousConfigFilePath2 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/postgresql.conf`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath1 = `${newConfigFolder}/pg_hba.conf`;
		const newConfigFilePath2 = `${newConfigFolder}/postgresql.conf`;

		

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath1, newConfigFilePath1);
		fs.copyFileSync(previousConfigFilePath2, newConfigFilePath2);

		const newPort = addPort(`postgres ${newVersion}`);

		let content = fs.readFileSync(newConfigFilePath1, 'utf8');
		fs.writeFileSync(newConfigFilePath1, content);

		content = fs.readFileSync(newConfigFilePath2, 'utf8');
		content = content.replace(/^port = .*$/m, `port = ${newPort}`);
		fs.writeFileSync(newConfigFilePath2, content);

		await copyInstallFile(program, newVersion);
	}
})();