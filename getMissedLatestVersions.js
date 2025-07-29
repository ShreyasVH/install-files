const fs = require('fs');
const os = require('os');

const latestVersions = JSON.parse(fs.readFileSync('latestVersions.json').toString());

const getFiles = path => {
    return fs.readdirSync(path).filter(file => !['.DS_Store'].includes(file));
};

const getFolders = (path) => {
	const files = getFiles(path);
	return files.filter(file => {
		return fs.statSync(path + '/' + file).isDirectory();
	});
}

const missingVersions = {};


const programs = getFolders('./macos');

const missed = [];

for (const program of programs) {
	if (!latestVersions.hasOwnProperty(program)) {
		missed.push(program);
	}
}


fs.writeFileSync('missedVersions.json', JSON.stringify(missed, null, ' '));