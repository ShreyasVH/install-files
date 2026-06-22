const path = require('path');
const fs = require('fs');
const { getFolders } = require('../utils');

const program = 'node';

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

const getPreviousVersion = () => {
	const folderPath = path.resolve(__dirname, '../../') + '/' + process.env.OS_FOLDER + '/' + program;

	const folders = getFolders(folderPath);

	folders.sort(compareVersions);
	return folders[folders.length - 1];
};

(async () => {

	const newVersion = process.argv[2];
	console.log(newVersion);

	const versionHistoryFilePath = 'versionHistory.json';
    const versionHistory = JSON.parse(fs.readFileSync(versionHistoryFilePath).toString());

    const staticCersionHistoryFilePath = 'staticVersionHistory.json';
    const staticVersionHistory = JSON.parse(fs.readFileSync(staticCersionHistoryFilePath).toString());

    const allVersions = Object.assign(versionHistory, staticVersionHistory);

    if (allVersions.hasOwnProperty(program) && allVersions[program].filter(v => v.version === newVersion).length === 1) {
    	const previousVersion = getPreviousVersion();

    	const filePath = `${path.resolve(__dirname, '../../')}/${process.env.OS_FOLDER}/${program}/${previousVersion}/install.sh`;

    	const newFolder = `${path.resolve(__dirname, '../../')}/${process.env.OS_FOLDER}/${program}/${newVersion}`;
    	const newFilePath = `${newFolder}/install.sh`;

    	fs.mkdirSync(newFolder);
    	fs.copyFileSync(filePath, newFilePath);
    }
})();