const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'kibana';

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/kibana.yml`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath = `${newConfigFolder}/kibana.yml`;

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath, newConfigFilePath);

		const newHttpPort = addPort(`kibana ${newVersion}`);
		const elasticsearchPort = addPort(`elasticsearch ${newVersion} http`);

		let content = fs.readFileSync(newConfigFilePath, 'utf8');
		content = content.replace(/^(server.port: .*)$/m, `server.port: ${newHttpPort}`);
		content = content.replace(/^(elasticsearch.hosts: .*)$/m, `elasticsearch.hosts: ['https://localhost:${elasticsearchPort}']`);
		fs.writeFileSync(newConfigFilePath, content);

		await copyInstallFile(program, newVersion);
	}
})();