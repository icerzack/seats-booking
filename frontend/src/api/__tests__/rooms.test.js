import axios from 'axios';
import { getAllRooms } from '../rooms';

jest.mock('axios');

describe('Rooms API', () => {
    const API_URL = 'http://77.244.220.121:10101/api/v1';

    afterEach(() => {
        jest.resetAllMocks();
    });

    describe('getAllRooms', () => {
        it('calls axios with default parameters and returns data', async () => {
            const mockResponse = {
                data: {
                    content: [{ id: 1, name: 'Room 1' }],
                    totalElements: 1,
                    totalPages: 1
                }
            };
            axios.get.mockResolvedValue(mockResponse);

            const result = await getAllRooms();

            expect(axios.get).toHaveBeenCalledWith(`${API_URL}/rooms`, {
                params: { page: 0, size: 20, sort: [] }
            });
            expect(result).toEqual(mockResponse.data);
        });

        it('calls axios with custom parameters and returns data', async () => {
            const page = 1;
            const size = 10;
            const sort = ['name,asc'];
            const mockResponse = {
                data: {
                    content: [{ id: 1, name: 'Room 1' }],
                    totalElements: 1,
                    totalPages: 1
                }
            };
            axios.get.mockResolvedValue(mockResponse);

            const result = await getAllRooms(page, size, sort);

            expect(axios.get).toHaveBeenCalledWith(`${API_URL}/rooms`, {
                params: { page, size, sort }
            });
            expect(result).toEqual(mockResponse.data);
        });
    });
});