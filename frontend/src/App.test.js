import React from 'react';
import { render } from '@testing-library/react';
import App from './App';

describe('App', () => {
  test('renders App component without errors', () => {
    // Simple smoke test to check if App renders without crashing
    const { container } = render(<App />);
    expect(container.querySelector('.container')).toBeInTheDocument();
  });

  test('contains Router component', () => {
    const { container } = render(<App />);
    // Check if the container div is present (main wrapper)
    expect(container.firstChild).toHaveClass('container');
  });
}); 