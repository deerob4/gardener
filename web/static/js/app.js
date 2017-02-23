import 'whatwg-fetch'

const messageContainer = document.querySelector('.message-container');
const goal = document.getElementById('goal');
const generationContainer = document.getElementById('generationContainer');
const form = document.getElementById('tuttiForm');
const errorContainer = document.querySelector('.error-container');

form.addEventListener('submit', (e) => {
  e.preventDefault();
  messageContainer.innerHTML = '';
  errorContainer.innerHTML = '';
  generationContainer.innerHTML = '';

  if (goal.value.length <= 50) {
    fetch(`/grow?goal=${goal.value}`)
      .then(r => r.json())
      .then(r => displayGenerations(r.generations, r.by_fitness.length));
  } else {
    const errorText = 'Breeding more than 50 genes together is dangerous!';
    errorContainer.appendChild(document.createTextNode(errorText));
  }
});

const displayGenerations = (generations, count) => {
  const geneCount = generations[0].sequence.length * 1000;
  const messageText = `Wow, just look what you can make with ${geneCount} fresh, juicy genes! To make your phrase, we cross-bred ${count} chromosomes together. Now that's incest!`;
  const message = document.createElement('h3');
  message.appendChild(document.createTextNode(messageText));
  messageContainer.appendChild(message);

  for (let i = 0; i < generations.length; i++) {
    const generation = generations[i];
    const contents = `Gen ${i+1}: ${generation.sequence}\t(${generation.fitness})`

    const genNumber = document.createElement('span');
    genNumber.classList = ['gen-number'];
    genNumber.appendChild(document.createTextNode(`Gen ${i+1}`));

    const sequence = document.createElement('span');
    sequence.classList = ['sequence'];
    sequence.appendChild(document.createTextNode(generation.sequence));

    const fitness = document.createElement('span');
    fitness.classList = ['fitness'];
    fitness.appendChild(document.createTextNode(`(${generation.fitness})`));

    const generationElement = document.createElement('li');
    generationElement.classList = ['generation'];
    generationElement.appendChild(genNumber);
    generationElement.appendChild(sequence);
    generationElement.appendChild(fitness);
    generationContainer.appendChild(generationElement);
  }
}
