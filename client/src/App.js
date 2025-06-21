import './App.css';
import ErrorBoundary from './Components/ErrorBoundary';
import Home from './Pages/Home';
import { BrowserRouter } from 'react-router-dom';
import AppRouter from './routes/Router';

function App() {
  return (
    <ErrorBoundary>
      <BrowserRouter  future={{
    v7_startTransition: true,
    v7_relativeSplatPath: true
  }}>
        <AppRouter></AppRouter>
      </BrowserRouter>
    </ErrorBoundary>
  );
}

export default App;
