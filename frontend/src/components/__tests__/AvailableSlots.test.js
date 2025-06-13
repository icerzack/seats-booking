import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import AvailableSlots from '../AvailableSlots';
import { getAvailableSlots } from '../../api/bookings';
import { getAllRooms } from '../../api/rooms';

jest.mock('../../api/bookings');
jest.mock('../../api/rooms');

describe('AvailableSlots', () => {
    const mockRooms = {
        content: [
            { id: 1, name: 'Conference Room' },
            { id: 2, name: 'Meeting Room' }
        ]
    };

    const mockSlots = [
        {
            startTime: '2024-12-25T09:00',
            endTime: '2024-12-25T10:00',
            booked: false
        },
        {
            startTime: '2024-12-25T10:00',
            endTime: '2024-12-25T11:00',
            booked: true
        }
    ];

    beforeEach(() => {
        getAllRooms.mockResolvedValue(mockRooms);
        getAvailableSlots.mockResolvedValue(mockSlots);
    });

    afterEach(() => {
        jest.resetAllMocks();
    });

    it('renders loading state initially', () => {
        render(<AvailableSlots roomId={1} />);
        expect(screen.getByText(/Loading room information.../i)).toBeInTheDocument();
    });

    it('renders component with room ID after loading', async () => {
        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information.../i)).not.toBeInTheDocument();
        });

        expect(screen.getByText('Room id: 1')).toBeInTheDocument();
        expect(screen.getByRole('button', { name: /Get Slots/i })).toBeInTheDocument();
        expect(screen.getByRole('button', { name: /Get Slots/i })).toBeDisabled();
    });

    it('enables button when date is selected', async () => {
        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information.../i)).not.toBeInTheDocument();
        });

        const dateInput = screen.getByDisplayValue('');
        fireEvent.change(dateInput, { target: { value: '2024-12-25' } });

        expect(screen.getByRole('button', { name: /Get Slots/i })).not.toBeDisabled();
    });

    it('fetches and displays available slots', async () => {
        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information.../i)).not.toBeInTheDocument();
        });

        const dateInput = screen.getByDisplayValue('');
        fireEvent.change(dateInput, { target: { value: '2024-12-25' } });

        const getSlotsButton = screen.getByRole('button', { name: /Get Slots/i });
        
        // Reset mock to ensure clean state
        getAvailableSlots.mockResolvedValueOnce(mockSlots);
        
        fireEvent.click(getSlotsButton);

        await waitFor(() => {
            expect(getAvailableSlots).toHaveBeenCalledWith(1, '2024-12-25');
        });

        await waitFor(() => {
            expect(screen.getByText('Start Time: 2024-12-25T09:00')).toBeInTheDocument();
        });

        expect(screen.getByText('End Time: 2024-12-25T10:00')).toBeInTheDocument();
        expect(screen.getByText('Status: Available')).toBeInTheDocument();
        expect(screen.getByText('Status: Booked')).toBeInTheDocument();
    });

    it('displays available and booked slot indicators correctly', async () => {
        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information.../i)).not.toBeInTheDocument();
        });

        const dateInput = screen.getByDisplayValue('');
        fireEvent.change(dateInput, { target: { value: '2024-12-25' } });

        getAvailableSlots.mockResolvedValueOnce(mockSlots);
        
        const getSlotsButton = screen.getByRole('button', { name: /Get Slots/i });
        fireEvent.click(getSlotsButton);

        await waitFor(() => {
            expect(screen.getByText('✓')).toBeInTheDocument(); // Available slot
        });
        expect(screen.getByText('✖')).toBeInTheDocument(); // Booked slot
    });

    it('displays message when no slots are available', async () => {
        getAvailableSlots.mockResolvedValueOnce([]);

        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information.../i)).not.toBeInTheDocument();
        });

        const dateInput = screen.getByDisplayValue('');
        fireEvent.change(dateInput, { target: { value: '2024-12-25' } });

        const getSlotsButton = screen.getByRole('button', { name: /Get Slots/i });
        fireEvent.click(getSlotsButton);

        await waitFor(() => {
            expect(screen.getByText('No slots available for the selected date')).toBeInTheDocument();
        });
    });

    it('handles error when fetching room data', async () => {
        getAllRooms.mockRejectedValueOnce(new Error('Failed to fetch'));

        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.getByText('Failed to fetch room data')).toBeInTheDocument();
        });
    });

    it('handles error when fetching slots', async () => {
        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information.../i)).not.toBeInTheDocument();
        });

        getAvailableSlots.mockRejectedValueOnce(new Error('Failed to fetch slots'));

        const dateInput = screen.getByDisplayValue('');
        fireEvent.change(dateInput, { target: { value: '2024-12-25' } });

        const getSlotsButton = screen.getByRole('button', { name: /Get Slots/i });
        fireEvent.click(getSlotsButton);

        await waitFor(() => {
            expect(screen.getByText('Failed to fetch available slots')).toBeInTheDocument();
        });
    });

    it('finds and sets room name when room exists', async () => {
        const mockRoomsWithDifferentRoom = {
            content: [
                { id: 2, name: 'Meeting Room' },
                { id: 1, name: 'Conference Room' }
            ]
        };
        getAllRooms.mockResolvedValueOnce(mockRoomsWithDifferentRoom);

        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information.../i)).not.toBeInTheDocument();
        });

        expect(getAllRooms).toHaveBeenCalled();
    });

    it('handles room not found scenario', async () => {
        const mockRoomsWithoutTargetRoom = {
            content: [
                { id: 2, name: 'Meeting Room' },
                { id: 3, name: 'Board Room' }
            ]
        };
        getAllRooms.mockResolvedValueOnce(mockRoomsWithoutTargetRoom);

        render(<AvailableSlots roomId={1} />);

        await waitFor(() => {
            expect(screen.queryByText(/Loading room information.../i)).not.toBeInTheDocument();
        });

        expect(screen.getByText('Room id: 1')).toBeInTheDocument();
    });

    test('renders room id', async () => {
        render(<AvailableSlots roomId={1} />);
        
        // Wait for loading to complete
        await screen.findByText('Room id: 1');
        
        expect(screen.getByText('Room id: 1')).toBeInTheDocument();
    });

    test('renders date selector', async () => {
        render(<AvailableSlots roomId={1} />);
        
        // Wait for loading to complete
        await screen.findByText('Room id: 1');
        
        expect(screen.getByRole('button', { name: 'Get Slots' })).toBeInTheDocument();
        expect(screen.getByDisplayValue('')).toBeInTheDocument();
    });
});