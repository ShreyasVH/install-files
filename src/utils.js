const fs = require('fs');

const merge = (a, b) => {
	const mergedObject = {};
	for (const key of Object.keys(a)) {
		mergedObject[key] = a[key].concat(b[key] || []);
	}

	for (const key of Object.keys(b)) {
		if (!a.hasOwnProperty(key)) {
			mergedObject[key] = b[key];
		}
	}

	for (const key of Object.keys(mergedObject)) {
		mergedObject[key] = mergedObject[key].filter((item, index) => mergedObject[key].indexOf(item) === index);
	}

	return mergedObject;
}

const capitalize = word => {
	return word[0].toUpperCase() + word.substring(1).toLowerCase();
};

const getFiles = path => {
    return fs.readdirSync(path).filter(file => !['.DS_Store'].includes(file));
};

const getFolders = (path) => {
	const files = getFiles(path);
	return files.filter(file => {
		return fs.statSync(path + '/' + file).isDirectory();
	});
};

const addPort = (title) => {
	const filePath = 'ports.csv';
	const lines = fs.readFileSync(filePath, 'utf8').split(/\r?\n/);

	let newPort = '';
	const updatedLines = lines.map((line, index) => {
	    if (index > 1025 && line === '' && newPort === '') {
	        newPort = index + 1;
	        return title;
	    }
	    return line;
	});

	fs.writeFileSync(filePath, updatedLines.join('\n'));

	return newPort;
};

exports.merge = merge;
exports.capitalize = capitalize;
exports.getFolders = getFolders;
exports.getFiles = getFiles;
exports.addPort = addPort;