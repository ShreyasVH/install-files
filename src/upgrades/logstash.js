const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'logstash';

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath1 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/logstash.yml`;
		const previousConfigFilePath2 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/logstash.conf`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath1 = `${newConfigFolder}/logstash.yml`;
		const newConfigFilePath2 = `${newConfigFolder}/logstash.conf`;

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath1, newConfigFilePath1);
		fs.copyFileSync(previousConfigFilePath2, newConfigFilePath2);

		const newHttpPort = addPort(`logstash ${newVersion} monitoring port`);
		const elasticsearchPort = addPort(`elasticsearch ${newVersion} http`);

		let content = fs.readFileSync(newConfigFilePath1, 'utf8');
		content = content.replace(/^(api.http.port: .*)$/m, `api.http.port: ${newHttpPort}`);
		fs.writeFileSync(newConfigFilePath1, content);

		content = fs.readFileSync(newConfigFilePath2, 'utf8');
		content = content.replace(/(hosts => .*)$/m, `hosts => ["https://localhost:${elasticsearchPort}"]`);
		fs.writeFileSync(newConfigFilePath2, content);

		await copyInstallFile(program, newVersion);
	}
})();