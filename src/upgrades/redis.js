const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'redis';

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {
		const previousConfigFilePath1 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/redis.conf`;
		const previousConfigFilePath2 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/sentinel.conf`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath1 = `${newConfigFolder}/redis.conf`;
		const newConfigFilePath2 = `${newConfigFolder}/sentinel.conf`;

		

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath1, newConfigFilePath1);
		fs.copyFileSync(previousConfigFilePath2, newConfigFilePath2);

		const newRedisPort = addPort(`redis ${newVersion}`);
		const newSentinelPort = addPort(`sentinel ${newVersion}`);

		let content = fs.readFileSync(newConfigFilePath1, 'utf8');
		content = content.replace(/^port .*$/m, `port ${newRedisPort}`);
		content = content.replace(/redis_.*\.pid/m, `redis_${newRedisPort}.pid`);
		fs.writeFileSync(newConfigFilePath1, content);

		content = fs.readFileSync(newConfigFilePath2, 'utf8');
		content = content.replace(/^port .*$/m, `port ${newSentinelPort}`);
		content = content.replace(/sentinel_.*\.pid/m, `sentinel_${newSentinelPort}.pid`);
		content = content.replace(/127.0.0.1 (\d){4}/m, `127.0.0.1 ${newRedisPort}`);
		fs.writeFileSync(newConfigFilePath2, content);

		await copyInstallFile(program, newVersion);
	}
})();