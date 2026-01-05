# reTerminal GPIO Control UI

Cyberpunk-themed React frontend for controlling Raspberry Pi GPIO pins on the reTerminal.

## Features

- **Cyberpunk aesthetic** with animated backgrounds, glowing effects, and futuristic styling
- **Touch-optimized** interface for 5" touchscreen (720x1280)
- **Real-time monitoring** via WebSocket connection
- **GPIO control** for digital I/O and PWM
- **Responsive layout** for portrait display orientation

## Development

### Prerequisites
- Node.js 16+ and npm
- Flask backend running on localhost:5000 (or update `.env`)

### Setup
```bash
cd frontend
npm install
cp .env.example .env
# Edit .env if backend is not on localhost:5000
```

### Run Development Server
```bash
npm start
# Opens on http://localhost:3000
```

### `npm test`

Launches the test runner in the interactive watch mode.\
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can’t go back!**

If you aren’t satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you’re on your own.

You don’t have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn’t feel obligated to use this feature. However we understand that this tool wouldn’t be useful if you couldn’t customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).
