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

exports.merge = merge;