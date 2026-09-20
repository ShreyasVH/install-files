const path = require('path');
const fs = require('fs');
const { getFolders } = require('../utils');

const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const compareVersions = (a, b) => {
	const pa = a.split('.').map(Number);
  	const pb = b.split('.').map(Number);

  	const len = Math.max(pa.length, pb.length);

  	for (let i = 0; i < len; i++) {
    	const na = pa[i] ?? 0;
    	const nb = pb[i] ?? 0;

    	if (na !== nb) {
      		return na - nb;
    	}
  	}

  	return 0;
};

const getPreviousVersion = (program) => {
	const folderPath = path.resolve(__dirname, '../../') + '/' + process.env.OS_FOLDER + '/' + program;

	const folders = getFolders(folderPath);

	folders.sort(compareVersions);
	return folders[folders.length - 1];
};

const copyInstallFile = (program, newVersion) => {
	const versionHistoryFilePath = 'versionHistory.json';
    const versionHistory = JSON.parse(fs.readFileSync(versionHistoryFilePath).toString());

    const staticCersionHistoryFilePath = 'staticVersionHistory.json';
    const staticVersionHistory = JSON.parse(fs.readFileSync(staticCersionHistoryFilePath).toString());

    const allVersions = Object.assign(versionHistory, staticVersionHistory);

    if (allVersions.hasOwnProperty(program) && allVersions[program].filter(v => v.version === newVersion).length === 1) {
    	const previousVersion = getPreviousVersion(program);

    	const filePath = `${path.resolve(__dirname, '../../')}/${process.env.OS_FOLDER}/${program}/${previousVersion}/install.sh`;

    	const newFolder = `${path.resolve(__dirname, '../../')}/${process.env.OS_FOLDER}/${program}/${newVersion}`;
    	const newFilePath = `${newFolder}/install.sh`;

    	fs.mkdirSync(newFolder);
    	fs.copyFileSync(filePath, newFilePath);
    }
};

exports.copyInstallFile = copyInstallFile;
exports.getPreviousVersion = getPreviousVersion;

if (fileName === scriptName) {
	(async () => {

		const program = process.argv[2];
		const newVersion = process.argv[3];

		const previousVersion = getPreviousVersion(program);

		if (newVersion !== previousVersion) {
			copyInstallFile(program, newVersion);
		}
	})();
}
