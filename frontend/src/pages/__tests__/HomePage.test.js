import React from 'react';
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import HomePage from '../HomePage';

describe('HomePage Component', () => {
  it('renders welcome message', () => {
    render(
      <MemoryRouter initialEntries={['/']}>
        <HomePage />
      </MemoryRouter>
    );

    expect(screen.getByText('Welcome')).toBeInTheDocument();
  });

  it('displays navigation links', () => {
    render(
      <MemoryRouter initialEntries={['/']}>
        <HomePage />
      </MemoryRouter>
    );

    expect(screen.getByText('My Bookings')).toBeInTheDocument();
    expect(screen.getByText('Rooms')).toBeInTheDocument();
  });

  it('does not show back button on the home page', () => {
    render(
      <MemoryRouter initialEntries={['/']}>
        <HomePage />
      </MemoryRouter>
    );

    const backButton = screen.queryByText('Back to Home');
    expect(backButton).not.toBeInTheDocument();
  });

  it('shows back button when not on the home page', () => {
    render(
      <MemoryRouter initialEntries={['/other-page']}>
        <Routes>
          <Route path="/other-page" element={<HomePage />} />
        </Routes>
      </MemoryRouter>
    );

    expect(screen.getByText('Back to Home')).toBeInTheDocument();
  });

  it('has correct navigation links to bookings and rooms', () => {
    render(
      <MemoryRouter initialEntries={['/']}>
        <HomePage />
      </MemoryRouter>
    );

    const bookingsLink = screen.getByText('My Bookings');
    const roomsLink = screen.getByText('Rooms');

    expect(bookingsLink.getAttribute('href')).toBe('/bookings');
    expect(roomsLink.getAttribute('href')).toBe('/rooms');
  });
});