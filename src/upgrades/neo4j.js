const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'neo4j';

	const previousVersion = getPreviousVersion(program);

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath1 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/neo4j.conf`;
		const previousConfigFilePath2 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/neo4j-admin.conf`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath1 = `${newConfigFolder}/neo4j.conf`;
		const newConfigFilePath2 = `${newConfigFolder}/neo4j-admin.conf`;

		// console.log(previousConfigFilePath);
		// console.log(newConfigFilePath);

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath1, newConfigFilePath1);
		fs.copyFileSync(previousConfigFilePath2, newConfigFilePath2);

		const newHttpPort = addPort(`neo4j ${newVersion} http`);
		const newBoltPort = addPort(`neo4j ${newVersion} bolt`);

		let content = fs.readFileSync(newConfigFilePath1, 'utf8');
		content = content.replace(/^(server.http.listen_address=:.*)$/m, `server.http.listen_address=:${newHttpPort}`);
		content = content.replace(/^(server.bolt.listen_address=:.*)$/m, `server.bolt.listen_address=:${newBoltPort}`);
		fs.writeFileSync(newConfigFilePath1, content);

		await copyInstallFile(program, newVersion);
	}
})();