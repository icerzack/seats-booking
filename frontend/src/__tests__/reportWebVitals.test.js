import reportWebVitals from '../reportWebVitals';

// Mock web-vitals module
jest.mock('web-vitals', () => ({
  getCLS: jest.fn(),
  getFID: jest.fn(),
  getFCP: jest.fn(),
  getLCP: jest.fn(),
  getTTFB: jest.fn(),
}));

describe('reportWebVitals', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('does not call web-vitals when onPerfEntry is null', async () => {
    const { getCLS, getFID, getFCP, getLCP, getTTFB } = await import('web-vitals');
    
    reportWebVitals(null);
    
    // Wait a bit to ensure no async calls
    await new Promise(resolve => setTimeout(resolve, 0));
    
    expect(getCLS).not.toHaveBeenCalled();
    expect(getFID).not.toHaveBeenCalled();
    expect(getFCP).not.toHaveBeenCalled();
    expect(getLCP).not.toHaveBeenCalled();
    expect(getTTFB).not.toHaveBeenCalled();
  });

  it('does not call web-vitals when onPerfEntry is not a function', async () => {
    const { getCLS, getFID, getFCP, getLCP, getTTFB } = await import('web-vitals');
    
    reportWebVitals('not a function');
    
    // Wait a bit to ensure no async calls
    await new Promise(resolve => setTimeout(resolve, 0));
    
    expect(getCLS).not.toHaveBeenCalled();
    expect(getFID).not.toHaveBeenCalled();
    expect(getFCP).not.toHaveBeenCalled();
    expect(getLCP).not.toHaveBeenCalled();
    expect(getTTFB).not.toHaveBeenCalled();
  });

  it('calls reportWebVitals with a function', () => {
    const mockCallback = jest.fn();
    
    // Just test that the function accepts a callback
    expect(() => reportWebVitals(mockCallback)).not.toThrow();
    
    // Verify the function is properly defined
    expect(typeof reportWebVitals).toBe('function');
  });

  it('handles undefined onPerfEntry', async () => {
    const { getCLS, getFID, getFCP, getLCP, getTTFB } = await import('web-vitals');
    
    reportWebVitals(undefined);
    
    // Wait a bit to ensure no async calls
    await new Promise(resolve => setTimeout(resolve, 0));
    
    expect(getCLS).not.toHaveBeenCalled();
    expect(getFID).not.toHaveBeenCalled();
    expect(getFCP).not.toHaveBeenCalled();
    expect(getLCP).not.toHaveBeenCalled();
    expect(getTTFB).not.toHaveBeenCalled();
  });
}); 