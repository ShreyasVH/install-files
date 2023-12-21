const path = require('path');
const getMissingInslallFiles = require(path.resolve('./getMissingInstallFiles.js')).getMissingInslallFiles;
const merge = require('./utils.js').merge;

const fs = require('fs');

const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

if (fileName === scriptName) {
	(async () => {
		const programs = {
			'java': [
				'8.0.382',
				'11.0.19',
				'17.0.7',
				'19',
				'19.0.2',
				'20.0.2',
				'21',
				'21.0.1'
			],
			'python': [
				'3.11.4'
			],
			'php': [
				'8.2.7',
				'8.2.8',
				'8.2.9',
				'8.2.10',
				'8.2.11'
			],
			'ruby': [
				'3.2.2'
			],
			'go': [
				'1.21.4'
			],
			'scala': [
				'3.2.2',
				'3.3.1'
			],
			'kotlin': [
				'1.9.20'
			],
			'perl': [
				'5.38.0'
			],
			'redis': [
				'7.0.12',
				'7.0.13',
				'7.2.1',
				'7.2.2'
			],
			'memcached': [
				'1.6.21',
				'1.6.22'
			],
			'rmq': [
				'3.12.2'
			],
			'apache': [
				'2.4.55',
				'2.4.56',
				'2.4.57',
				'2.4.58'
			],
			'nginx': [
				'1.25.1',
				'1.25.3'
			],
			'mysql': [
				'8.0.34',
				'8.1.0'
			],
			'mongo': [
				'6.0.6', 
				'7.0.1',
				'7.0.3',
				'7.1.1'
			],
			'postgres': [
				'15.3',
				'15.4',
				'16.0',
				'16.1'
			],
			'neo4j': [
				'5.11.0',
				'5.13.0'
			],
			'elasticsearch': [
				'7.16.3',
				'7.17.15',
				'8.9.2',
				'8.10.0',
				'8.10.1',
				'8.10.2',
				'8.10.3',
				'8.10.4',
				'8.11.0',
				'8.11.1'
			],
			'kibana': [
				'8.9.2',
				'8.11.1'
			],
			'haproxy': [
				'2.8.2',
				'2.8.3'
			],
			'maven': [
				'3.8.8',
				'3.9.5'
			],
			'sbt': [
				'1.7.2',
				'1.8.1',
				'1.9.7'
			],
			'dotnet-core': [
				'7.0.402',
				'8.0.100'
			],
			'rsyslog': [
				'8.2308.0'
			],
			'node': [
				'16.3.0',
				'18.16.0',
				'19.9.0'
			]
		};

		let allMissingInstallFiles = {};
		const specifiMissingFiles = {};

		for (const [programName, versions] of Object.entries(programs)) {
			for (const version of versions) {
				const missingInstallFiles = getMissingInslallFiles(programName, version);
				allMissingInstallFiles = merge(allMissingInstallFiles, missingInstallFiles);
				if (Object.keys(missingInstallFiles).length > 0) {
					if (!specifiMissingFiles.hasOwnProperty(programName)) {
						specifiMissingFiles[programName] = {};
					}
					specifiMissingFiles[programName][version] = missingInstallFiles;
				}
			}
		}
		console.log(allMissingInstallFiles);
		console.log('----------------');
		console.log(JSON.stringify(specifiMissingFiles, null, ' '));
	})();
}