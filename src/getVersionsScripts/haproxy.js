const puppeteer = require('puppeteer');
const fs = require('fs');

const path = require('path');
const scriptName = path.basename(__filename);
const fileNameParts = process.argv[1].split(path.sep);
const fileName = fileNameParts[fileNameParts.length - 1];

const getAllVersionsMainFromHTML = () => {
	const versionElements = [...document.querySelectorAll('a')].filter((ele, index) => {
		const text = ele.innerText.replace('/', '');

		const regex = new RegExp("\\d+\\.\\d+");
		const matches = text.match(regex);
		return matches !== null && matches[0] === text;
	});

	return versionElements.map(ele => ele.innerText.replace('/', '')).slice(1);
};

const getAllVersionsFromHTML = () => {
	const versionElements = [...document.querySelectorAll('a')];

	const versions = [];

	for (const ele of versionElements) {
		const text = ele.innerText;

		const regex = new RegExp("^haproxy-(\\d+\\.\\d+\\.\\d+).tar.gz$");
		const matches = text.match(regex);
		if (matches !== null && matches[0] === text) {
			const version = matches[1];

			const nextElement = ele.nextSibling;
			const dateText = nextElement.textContent.trim().replaceAll('  ', ' ');
			const dateParts = dateText.split(' ');
			const releaseDateString = dateParts[0] + " " + dateParts[1];
			
			versions.push({
				version,
				releaseDateString
			});
		}
	}

	return versions;
};


const getAllVersions = async () => {
	const baseUrl = 'https://www.haproxy.org/download/';
	const program = 'haproxy';

	const programData = JSON.parse(fs.readFileSync('programData.json').toString());
    const versionHistoryFilePath = 'versionHistory.json';
    const versionHistory = JSON.parse(fs.readFileSync(versionHistoryFilePath).toString());

    const allVersionsFilePath = 'allVersions.json';
    const allVersionsData = JSON.parse(fs.readFileSync(allVersionsFilePath).toString());

	const browser  = await puppeteer.launch({
		headless: 'shell'
	});

    let allVersions = ((allVersionsData.hasOwnProperty(program)) ? allVersionsData[program] : []);
    const originalVersionLength = allVersions.length;

    console.log(allVersions.length);

    console.log(baseUrl);
	const page = await browser.newPage();
    await page.goto(baseUrl, {
        waitUntil: 'networkidle2',
        timeout: 0
    });
    page.on('console', msg => console.log('PAGE LOG:', msg.text()));

    const versionsResponse = (await page.evaluate(getAllVersionsMainFromHTML)).reverse();
    // console.log(versionsResponse);

    for (const version of versionsResponse) {
    	const subVersionUrl = baseUrl + version + '/src/';
    	console.log(subVersionUrl);

    	await page.goto(subVersionUrl, {
    	    waitUntil: 'networkidle2',
    	    timeout: 0
    	});
    	page.on('console', msg => console.log('PAGE LOG:', msg.text()));

    	const subVersions = await page.evaluate(getAllVersionsFromHTML);

    	const existingVersions = allVersions.map(item => item.version);

    	const newVersions = subVersions.filter(item => !existingVersions.includes(item.version));

    	allVersions = newVersions.concat(allVersions);
    }

	await page.close();

    await browser.close();


    
    versionHistory[program] = allVersions;
    fs.writeFileSync(versionHistoryFilePath, JSON.stringify(versionHistory, null, ' '));

    
    allVersionsData[program] = allVersions;
    fs.writeFileSync(allVersionsFilePath, JSON.stringify(allVersionsData, null, ' '));
};

exports.getAllVersions = getAllVersions;

if (fileName === scriptName) {
	(async () => {
		await getAllVersions();
	})();
}

