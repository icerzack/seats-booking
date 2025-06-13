package vasilkov.seats_booking_backend.entity.utils;

import lombok.AccessLevel;
import lombok.Generated;
import lombok.NoArgsConstructor;

/**
 * @author:Ioutcast | Vasilkov.A.S
 * @date:3/11/2025
 * @time:8:45 PM
 */
@Generated
@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class ColumnLength {

    /**
     * Длина строкового поля при денормализации или для записи комментария.
     */
    public static final int CL_FIELD_DENORM_DOMAIN = 8000;

    /**
     * Длина строкового поля.
     */
    public static final int CL_FILED_LENGTH = 2000;
}
