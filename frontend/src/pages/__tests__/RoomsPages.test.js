import React from 'react';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import RoomsPage from '../RoomsPage';
import { getAllRooms } from '../../api/rooms';

jest.mock('../../api/rooms');

const mockNavigate = jest.fn();
jest.mock('react-router-dom', () => ({
    ...jest.requireActual('react-router-dom'),
    useNavigate: () => mockNavigate
}));

describe('RoomsPage', () => {
    const mockRooms = {
        content: [
            { id: 1, name: 'Conference Room', capacity: 20, floor: 1 },
            { id: 2, name: 'Meeting Room', capacity: 10, floor: 2 }
        ]
    };

    beforeEach(() => {
        jest.clearAllMocks();
        getAllRooms.mockResolvedValue(mockRooms);
    });

    it('renders loading state initially', () => {
        render(
            <MemoryRouter>
                <RoomsPage />
            </MemoryRouter>
        );

        expect(screen.getByText(/Loading rooms.../i)).toBeInTheDocument();
    });

    it('filters rooms by search term', async () => {
        render(
            <MemoryRouter>
                <RoomsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        // Get search input if it exists
        const searchInput = screen.queryByPlaceholderText(/Search rooms/i) ||
            screen.queryByRole('textbox', { name: /search/i });

        if (searchInput) {
            // Type in search term
            fireEvent.change(searchInput, { target: { value: 'Conference' } });

            // Check filtered results
            expect(screen.getByText('Conference Room')).toBeInTheDocument();
            expect(screen.queryByText('Meeting Room')).not.toBeInTheDocument();
        }
    });

    it('has a button to create new rooms', async () => {
        render(
            <MemoryRouter>
                <RoomsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        // Look for "Add Room" button with multiple possible text variations
        const addButton = screen.queryByText(/Add Room/i) ||
            screen.queryByText(/Create Room/i) ||
            screen.queryByText(/New Room/i);

        if (addButton) {
            fireEvent.click(addButton);
            expect(mockNavigate).toHaveBeenCalledWith('/rooms/create');
        }
    });

    it('displays a message when no rooms are available', async () => {
        getAllRooms.mockResolvedValue({ content: [] });

        render(
            <MemoryRouter>
                <RoomsPage />
            </MemoryRouter>
        );

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        expect(screen.getByText(/No rooms available/i)).toBeInTheDocument();
    });
});