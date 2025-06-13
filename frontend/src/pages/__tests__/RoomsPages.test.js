import React from 'react';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import RoomsPage from '../RoomsPage';
import { getAllRooms } from '../../api/rooms';

jest.mock('../../api/rooms');
jest.mock('../../components/AvailableSlots', () => {
    return function MockAvailableSlots({ roomId }) {
        return <div data-testid="available-slots">Room id: {roomId}</div>;
    };
});

const MockedRoomsPage = () => (
    <BrowserRouter>
        <RoomsPage />
    </BrowserRouter>
);

describe('RoomsPage', () => {
    const mockRooms = {
        content: [
            { id: 1, name: 'Conference Room' },
            { id: 2, name: 'Meeting Room' }
        ]
    };

    beforeEach(() => {
        getAllRooms.mockResolvedValue(mockRooms);
    });

    afterEach(() => {
        jest.resetAllMocks();
    });

    it('renders loading state initially', () => {
        render(<MockedRoomsPage />);
        expect(screen.getByText(/Loading rooms.../i)).toBeInTheDocument();
    });

    it('renders rooms in dropdown after loading', async () => {
        render(<MockedRoomsPage />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        expect(screen.getByText('Conference Room')).toBeInTheDocument();
        expect(screen.getByText('Meeting Room')).toBeInTheDocument();
        
        const roomSelect = screen.getByLabelText(/Select a room:/i);
        expect(roomSelect).toBeInTheDocument();
    });

    it('renders AvailableSlots component when room is selected', async () => {
        render(<MockedRoomsPage />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        // AvailableSlots should be rendered automatically for the first room
        expect(screen.getByText('Room id: 1')).toBeInTheDocument();
    });

    it('handles API error', async () => {
        getAllRooms.mockRejectedValueOnce(new Error('Failed to fetch rooms'));

        render(<MockedRoomsPage />);

        await waitFor(() => {
            expect(screen.getByText('Failed to fetch rooms')).toBeInTheDocument();
        });
    });

    it('displays empty state when no rooms are available', async () => {
        getAllRooms.mockResolvedValueOnce({ content: [] });

        render(<MockedRoomsPage />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        expect(screen.getByText('No rooms available')).toBeInTheDocument();
    });

    it('renders page title', async () => {
        render(<MockedRoomsPage />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        expect(screen.getByText('Check Room Availability')).toBeInTheDocument();
    });

    it('handles room selection change', async () => {
        render(<MockedRoomsPage />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

        const roomSelect = screen.getByLabelText(/Select a room:/i);
        expect(roomSelect.value).toBe('1'); // First room selected by default
        
        fireEvent.change(roomSelect, { target: { value: '2' } });
        expect(roomSelect.value).toBe('2');
    });

    it('renders back to home link', async () => {
        render(<MockedRoomsPage />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading rooms.../i)).not.toBeInTheDocument();
        });

                 const backLink = screen.getByText('Back to Home');
         expect(backLink.closest('a')).toHaveAttribute('href', '/');
     });
 });