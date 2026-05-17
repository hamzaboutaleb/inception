const terminal = document.querySelector("code");

if (terminal) {
	const line = "status: ready for the next project";
	const text = `${terminal.textContent}\n${line}`;

	terminal.textContent = "";
	let index = 0;

	const tick = () => {
		terminal.textContent = text.slice(0, index);
		index += 1;

		if (index <= text.length) {
			window.setTimeout(tick, 12);
		}
	};

	tick();
}
